# EsnaftaVar Search Synonym Architecture

**State:** `PROVISIONAL SEARCH DESIGN — NO INDEX/RUNTIME IMPLEMENTATION`
**Coverage target:** owner-final 20 L2 plus proposed 224 L2

## Separation of concerns

- Taxonomy: **what is the product?**
- Facets: **what characteristics does it have?**
- Search vocabulary: **how may the customer refer to it?**
- Compatibility: **what does it work with?**
- Policy: **can/how may it be listed?**

A search term never creates a category, changes primary ownership, proves a product
fact or bypasses policy.

## Term types

| Type | Definition | Example | Canonical effect |
|---|---|---|---|
| `CANONICAL_CATEGORY_NAME` | Exact owner-final/proposed node display label | `Dizüstü Bilgisayar` | Highest taxonomy-name signal; proposal state remains proposal. |
| `CATEGORY_ALIAS` | Approved alternate category wording | `cep telefonu` | Resolves to node; does not rename it. |
| `SEARCH_SYNONYM` | Same/common customer concept used for retrieval | `taşınabilir şarj` | Candidate retrieval/boost only. |
| `LEGACY_ALIAS` | Historical display/path term retained for transition | controlled old label | Lower weight, monitored and deprecable. |
| `COMMON_ABBREVIATION` | Established abbreviation | `PPE`, `RC`, `TWS` | Requires domain/context when ambiguous. |
| `TECHNICAL_TERM` | Recognized technical/product term | `PCIe`, `rollerball` | Can match category/facet knowledge; no automatic fact extraction. |
| `COLLOQUIAL_TURKISH_TERM` | Customer/retail vernacular | `kırılmaz cam`, `suluk` | Discovery signal with collision review. |
| `ENGLISH_LOANWORD` | Turkish commerce usage of English term | `laptop`, `sneaker` | Locale-governed synonym, not translation wholesale. |
| `TYPO` | Misspelling/keyboard/diacritic error | `klavue`, `sarj` | Separate fuzzy/typo strategy; not canonical synonym by default. |

Ordinary typos are excluded from the controlled vocabulary unless there is evidence
that a stable misspelling has become a genuine lexical alias and owner/search review
explicitly approves it.

## Precedence and ranking

Default semantic precedence:

1. exact canonical category name;
2. exact approved category alias;
3. exact semantic synonym or technical term;
4. contextual colloquial/loanword/abbreviation;
5. legacy alias;
6. normalized token, spelling correction or fuzzy match.

This is not a numeric ranking formula. Product title, structured category, facet and
compatibility signals must be combined by a future search design. Brand/model exact
matches come from product/entity indexes, not category synonym entries.

## Normalization pipeline

1. preserve the raw query;
2. Unicode NFC and Turkish-aware lowercase/tokenization;
3. whitespace/punctuation normalization without losing units/model punctuation;
4. match exact phrase before token expansion;
5. resolve approved term entries and their target node state;
6. gather product title/facet/compatibility/domain context;
7. disambiguate collisions; do not force a single domain without sufficient signal;
8. apply typo/fuzzy strategy last and with lower confidence;
9. retain explanation/provenance for evaluation.

Diacritic-insensitive tokens (`şarj`/`sarj`) can support recall but do not create a
second synonym record. Unit/model tokens such as `5W-30`, `205/55 R16`, `USB-C` and
`15,6` need technical tokenization, not punctuation stripping.

## Collision handling

Every term entry can declare `AMBIGUOUS=YES` and an alternative domain. Ambiguous
terms are not globally one-to-one. Resolution signals, strongest first:

- longer exact phrase (`kontakt lens` before `lens`);
- explicit category/breadcrumb context;
- product-type tokens (`kamera lensi`, `hijyen pedi`, `bisiklet pedalı`);
- compatible target/vehicle/device entities;
- typed facet units and values;
- merchant/catalog context only as a weak prior;
- user clarification or multi-cluster results when evidence remains tied.

Empty context never grants the most commercially convenient meaning. Search can show
separated result groups instead of silently rewriting intent.

## Category, facet and policy interactions

- `128 GB`, `siyah`, `kadın`, `organik`, `Bluetooth` and model names query facets or
  product facts; they are not category synonyms.
- `tedavi eder`, certification, prescription and hazardous-goods wording may trigger
  policy filtering/review; they never open a prohibited category.
- A synonym can retrieve a proposed L2 for architecture evaluation, but the CSV must
  retain `PROPOSED_FOR_OWNER_REVIEW` state.
- A compatibility term (`for model X`) narrows candidates only through structured
  target evidence; title text cannot claim compatibility.

## Lifecycle and governance

Each controlled term needs a unique term concept ID, locale, type, target node,
canonical-node state, ambiguity metadata, provenance, status and review date in a
future implementation. Changes are governed as:

- add: evidence of customer usage and exact semantic/target review;
- change target: collision review and analytics/search regression check;
- deprecate: retain legacy mapping and replacement, do not silently delete history;
- promote typo: only explicit evidence/approval;
- proposed node finalization: update state after owner decision without changing term
  identity solely because status changed.

## Evaluation gates

A future index must be tested for:

- canonical exact-match precision;
- recall for Turkish/common/loanword vocabulary;
- collision precision by domain/context;
- zero policy bypass from search expansion;
- typo correction false-positive rate;
- no brand/model promotion into taxonomy;
- stable behavior across label rename/deprecation;
- owner-final and proposed node state visibility.

## Examples

| Query | Candidate interpretation | Required handling |
|---|---|---|
| `telefon`, `cep telefonu`, `smartphone` | Elektronik → Telefon & Aksesuarları | Same device family; OS/brand remain facets. |
| `laptop`, `notebook` | Bilgisayar & Tablet → Dizüstü Bilgisayar | Exact semantic synonyms. |
| `mouse`, `fare` | Computer peripheral vs animal/pet context | Product context required; no pet product assumption from `fare`. |
| `powerbank`, `power bank`, `taşınabilir şarj` | Elektronik → Güç, Şarj & Bağlantı | Spacing normalized; capacity is facet. |
| `matkap`, `delme makinesi` | powered tool intent | Hand/powered distinction and product title context. |
| `pasta` | cake/pastry vs foreign-language pasta | Turkish locale/product context; never global one-to-one. |

`SEARCH_TERM_TYPES: 9`

`ORDINARY_TYPOS_AS_CANONICAL_SYNONYMS: NO`

`SEARCH_SYNONYM_ARCHITECTURE: PASS`
