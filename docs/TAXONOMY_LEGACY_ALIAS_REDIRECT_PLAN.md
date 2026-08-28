# EsnaftaVar Legacy Taxonomy Alias and Redirect Plan

**State:** ANALYSIS ONLY — NO RUNTIME REDIRECTS OR ALIASES CREATED

## 1. Purpose

The legacy taxonomy uses slugs as its only exact locators. Renaming or moving a
node without a compatibility plan could break saved paths, documentation links,
merchant memory, search behavior, and historical reports. This plan preserves
useful legacy language while keeping identity redirects distinct from query
synonyms.

The exhaustive row-level signal is `ALIAS_REQUIRED` in
`docs/TAXONOMY_LEGACY_NODE_RECONCILIATION.csv`.

## 2. Inventory result

| Alias/redirect signal | Rows |
|---|---:|
| Total `ALIAS_REQUIRED=YES` | 93 |
| High-confidence MOVE | 60 |
| High-confidence RENAME | 8 |
| High-confidence RENAME_AND_MOVE | 9 |
| Owner-final SPLIT predecessor | 16 |
| High-confidence rename/move missing alias signal | 0 |

All 77 high-confidence rename/move rows are therefore explicitly marked for
legacy alias preservation. Proposed-domain renames are not activated as redirects
before owner finalization.

## 3. Typed compatibility model

| Type | Meaning | Resolution behavior |
|---|---|---|
| `LEGACY_REDIRECT` | Old official slug/path for the same stable semantic node | Resolves to one stable ID after collision/version checks. |
| `LEGACY_SPLIT` | Old official locator now has several successors | Resolves to a split landing/disambiguation result, never an arbitrary child. |
| `DISPLAY_ALIAS` | Previous official label for display/import compatibility | May identify the node but is not the canonical label. |
| `SEARCH_SYNONYM` | Customer query expansion | May retrieve one or several nodes/products; is not identity proof. |
| `MERCHANT_TERM` | Seller vocabulary | Search/import aid, optionally domain-scoped. |
| `TYPO_VARIANT` | Controlled spelling/normalization variant | Query normalization only unless separately approved as redirect. |

A synonym and a redirect are not interchangeable. `notebook` may be a search
synonym for `Dizüstü Bilgisayar`, while an old official node slug is a redirect
candidate. A synonym can intentionally fan out; an identity redirect cannot.

## 4. Owner-final L1 rename redirects

These eight high-confidence L1 renames should preserve the old slug as a future
`LEGACY_REDIRECT` to the owner-final stable ID:

| Old slug / label | Final label |
|---|---|
| `market-gida` / Market & Gıda | Gıda & İçecek |
| `moda-giyim` / Moda & Giyim | Giyim & Moda |
| `canta-giyim-aksesuari` / Çanta & Giyim Aksesuarı | Çanta & Aksesuar |
| `yapi-hirdavat` / Yapı & Hırdavat | Yapı, Hırdavat & Tesisat |
| `kisisel-bakim-kozmetik` / Kişisel Bakım & Kozmetik | Kozmetik & Kişisel Bakım |
| `bebek-cocuk` / Bebek & Çocuk | Anne & Bebek |
| `pet-shop` / Pet Shop | Evcil Hayvan Ürünleri |
| `optik` / Optik | Gözlük & Optik |

The L1 predecessor `oyuncak-hobi-muzik` is different: it is a split and must use
`LEGACY_SPLIT` toward both `Oyuncak & Hobi` and `Müzik & Enstrüman`.

## 5. Owner-final label changes

High-confidence final-domain examples where both old slug and old official label
should be retained include:

| Legacy label | Canonical successor label | Compatibility note |
|---|---|---|
| Akıllı Telefon | Akıllı Telefonlar | Singular/plural shift plus deeper phone path. |
| Tuşlu Cep Telefonu | Tuşlu Telefonlar | Terminology and plurality change. |
| Cep Telefonu Kılıfı | Telefon Kılıfları | Shorter canonical label and deeper path. |
| Ekran Koruyucu | Ekran Koruyucular | Plural canonical label. |
| Selfie Çubuğu & Uzaktan Kumanda | Telefon Kamera & Çekim Aksesuarları | Broader final leaf; preserve old term for discovery. |
| Telefon Yedek Bileşenleri | Telefon Yedek Parçaları | Official terminology change. |
| Telefon Bataryası | Telefon Bataryaları | Plural final leaf. |
| Telefon Ekran Modülü | Ekran & Dokunmatik Modülleri | Broader final module wording. |
| Bilgisayar Güç Kaynağı | Güç Kaynağı | PC domain supplies context; preserve PSU terminology in search. |

The remaining high-confidence MOVE rows generally retain their display names but
change parent/path. Their legacy path/slug still requires redirect preservation;
examples include chargers moving to `Güç, Şarj & Bağlantı`, SSD/HDD moving to
`Veri Depolama`, monitor becoming its own L2, and USB hub/dock moving to
`Bilgisayar Aksesuarları`.

## 6. Split redirect candidates

All 16 owner-final split predecessors are marked `ALIAS_REQUIRED=YES`. Important
non-one-to-one locators include:

- `oyuncak-hobi-muzik`;
- `telefon-giyilebilir-teknoloji`;
- `telefon-aksesuarlari`;
- `telefon-koruma-tasima`;
- `telefon-tutucu-giris-aksesuarlari` and leaf `telefon-tutucu`;
- `ses-goruntu-sistemleri`;
- `kamera-guvenlik-elektronigi`;
- `elektronik-guc-kablo-bilesen`;
- `bilgisayar-tablet-okuyucu`;
- `bilgisayar-bilesenleri`;
- `ana-bilgisayar-bilesenleri`;
- `kasa-guc-sogutma` and leaf `bilgisayar-sogutma`;
- `bilgisayar-cevre-birimleri`;
- `ag-harici-depolama-baski`.

These locators need a split registry entry. Where reliable product attributes do
not select a successor, the old locator should open a neutral disambiguation or
return an explicit reclassification-required result.

## 7. Search synonym candidates

Controlled customer-language candidates include:

- `cep telefonu`, `akıllı telefon`, `smartphone`;
- `dizüstü`, `notebook`, `laptop`;
- `masaüstü`, `desktop`, `PC`;
- `mouse`, `fare`, `mousepad`;
- `router`, `yönlendirici`, `modem`;
- `CPU`, `işlemci`; `GPU`, `ekran kartı`, `grafik kartı`;
- `RAM`, `bellek`; `PSU`, `güç kaynağı`;
- `kartuş`, `toner`; `dock`, `docking station`, `USB hub`.

These are recommendations for later search-quality review, not redirect rows and
not canonical category names. Brand terms, attributes, and compatibility values
must not become category aliases that silently change product assignment.

## 8. Alternative spelling and normalization controls

Turkish search normalization should treat dotted/dotless `i`, diacritics, common
hyphenation, and singular/plural variants as query concerns. Stored official
aliases should retain the exact original UTF-8 spelling and source version.

Avoid globally folding terms that can change meaning or collide across domains.
For example, `batarya` can mean a phone battery, vehicle battery, plumbing
fixture, or percussion set depending on context. Such terms require domain-scoped
search behavior rather than one global redirect.

## 9. Redirect acceptance rules

A future redirect import should fail closed unless:

1. canonical stable IDs exist;
2. the source slug and source taxonomy hash are recorded;
3. one-to-one redirects have exactly one active target;
4. split aliases reference an explicit successor set;
5. target state is owner-final, not provisional;
6. alias collisions are resolved;
7. retired/policy-gated nodes do not become assignable through redirect behavior;
8. deep-link, search, and analytics behavior are tested separately.

No redirect or synonym was installed by this audit.

