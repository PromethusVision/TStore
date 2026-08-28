# EsnaftaVar Facet Value Normalization

**State:** `PROVISIONAL DESIGN — NO RUNTIME IMPLEMENTATION`  
**Scope:** Values for the 88 concept facets; no DB, API, index or merchant UI schema

## Principle

Normalization makes equivalent facts comparable without discarding the submitted
source. `128GB`, `128 GB` and `128 gb` must resolve to one normalized storage value;
`Siyah`, `siyah` and the common English input `Black` must display under one Turkish
color family. Source text, normalized value, canonical display and provenance remain
separate.

Conceptual record:

| Layer | Purpose | Example |
|---|---|---|
| Source value | Exact vendor/import input for audit | `128GB`, `Black` |
| Parsed value | Typed number/enum/reference | `128` + `GB`; `color:black` |
| Normalized base | Comparable canonical representation | bytes/declared GB contract; `BLACK` |
| Display value | Locale-aware customer text | `128 GB`; `Siyah` |
| Provenance | Source, parser/rule version, time, confidence | merchant import; rule v1; verified |

Failed parsing never guesses a value. It yields `REVIEW_REQUIRED` or omits the
filterable normalized value while retaining safe source evidence.

## Unit and SI model

- Numeric magnitude and unit are stored separately in the design contract.
- Unit is selected from a facet-specific unit family; arbitrary suffixes are rejected.
- Canonical comparison uses a base unit; display may use a lossless scaled unit.
- Mass: `mg`, `g`, `kg`; length: `mm`, `cm`, `m`; liquid volume: `ml`, `L`;
  electrical: `mA`, `A`, `V`, `W`, `kW`, `mAh`, `Wh`; frequency: `Hz`, `kHz`,
  `MHz`, `GHz`; angle/temperature only in profiles that truly require them.
- Screen diagonal and standardized trade sizes may retain governed non-SI display
  (`inç`) while also carrying a comparison-safe metric value.
- Storage must declare the commercial/display convention; `GB` and `GiB` are not
  silently equated. Input case (`gb`) is normalized only after context confirms
  storage rather than network rate.
- `1 L = 1000 ml`, `1 kg = 1000 g` and exact metric conversions are allowed;
  approximate apparel/shoe/ring size conversions are never represented as exact.

## Turkish locale and text normalization

- Unicode NFC, trimmed/collapsed whitespace and Turkish-aware casing are used.
- Turkish `I/ı` and `İ/i` must not be normalized with an English-only lowercase rule.
- Decimal input accepts `1,5` in Turkish UI and controlled import `1.5`; canonical
  numeric value is decimal `1.5`, Turkish display is `1,5`.
- Thousands separators are interpreted only with declared locale/source contract;
  ambiguous `1.500` is not guessed as either one-and-a-half or one thousand five hundred.
- Display labels preserve Turkish diacritics. Search may additionally index an
  accent-insensitive token, but it is not the canonical value.
- Brand/model/manufacturer source strings are not translated or case-collapsed into
  one reference without entity reconciliation.

## Numeric values and ranges

| Input | Normalized meaning | Rule |
|---|---|---|
| `128GB`, `128 GB`, `128 gb` | `128` + governed `GB` display | Context must be storage capacity. |
| `1,5 L`, `1500 ml` | same base volume | Exact unit conversion. |
| `220-240V`, `220–240 V` | inclusive numeric range `220..240 V` | Preserve endpoints and range type. |
| `yaklaşık 2 kg` | `2 kg` + approximation flag | Do not strip uncertainty. |
| `15.6 inch`, `15,6 inç` | same screen diagonal | Only within screen-size profile. |
| `205/55 R16` | structured tire fields | Never parse as generic dimensions. |

Open, closed and one-sided ranges are explicit. `10+`, `<5`, `up to 20` and
`10–20` are different. Sort uses normalized numeric bounds; unknown values sort
after known values unless a product experience explicitly decides otherwise.

## Dimensions

Dimensions are a structured tuple with named axes, value, unit and measurement
context. `60×40×30 cm` is not accepted without a domain/profile-defined axis order.
Product dimensions, package dimensions, internal usable dimensions and folded
dimensions are distinct measurement contexts. Decimal rounding cannot make a
product pass a fit/compatibility constraint.

## Controlled enum values

Each controlled value has a concept value key, Turkish display label, accepted
input aliases, optional deprecation target and policy evidence requirements.

| Source variants | Canonical value/display | Notes |
|---|---|---|
| `Siyah`, `siyah`, `Black`, `black` | `BLACK` / `Siyah` | English term is an input/search alias, not duplicate enum. |
| `lacivert`, `navy`, `koyu mavi` | `NAVY` / `Lacivert` | `koyu mavi` can remain vendor shade if intent uncertain. |
| `evet`, `yes`, `true`, `1` | boolean `true` | Only declared boolean input channels. |
| `bilinmiyor`, blank, `-` | unknown/null | Never boolean `false`. |
| `uygulanamaz`, `N/A` | not-applicable | Separate from unknown. |

An enum cannot accept arbitrary values just because the UI label says `other`.
Unknown vendor values enter a quarantine/review queue and remain non-filterable
until mapped.

## Boolean and tri-state rules

- Boolean fields mean an objective property with only yes/no once evidence exists.
- `unknown` and `not_applicable` are metadata states, not boolean values.
- Absence never means `false`; unchecked merchant input remains unknown.
- Claim-like booleans (`waterproof`, `organic`, `hypoallergenic`, `certified`) need
  claim evidence state and cannot become true from title text alone.

## Multi-value rules

- Values are sets unless a profile explicitly needs rank/order.
- Duplicates are removed by canonical value key, not display string.
- Source order can be retained separately for ingredient/composition evidence.
- `all` is not a stored value; it is a query operation.
- Contradictory values (`compatible` and `incompatible` for the same target/rule
  version) trigger review rather than merge.

## Materials, colors and sizes

- Material uses a controlled family plus optional composition percentage; vendor
  marketing terms do not replace objective material.
- Color stores normalized family and optional vendor shade. Pattern and finish are
  separate concepts.
- Size label always includes its size system and audience/profile context.
- Approximate mappings such as `M ≈ 38/40`, EU↔UK shoe sizes and ring conversions
  are presentation aids with declared source tables, never identity equivalence.

## Free text

Free text is permitted only when a governed vocabulary cannot represent the fact
and the value is safe to display. It is not filterable/sortable by default. It must
never substitute for compatibility, medical intended use, certification, hazard,
dimensions, units, brand/model reference or policy eligibility. Length, language,
markup and prohibited-claim validation apply before display/indexing.

## Vendor-supplied values and synonym normalization

1. retain raw source and source identity;
2. normalize Unicode/whitespace with declared locale;
3. parse against the applicable facet profile;
4. map accepted value aliases to a canonical value concept;
5. record rule version and confidence;
6. reject ambiguity instead of choosing a convenient value;
7. reprocess when a mapping is governed/deprecated.

Search synonyms may help interpret a query but must not rewrite product facts.
Likewise a product attribute alias (`navy`) may map to a color value, but a category
alias (`notebook`) must not populate a hardware facet.

## Missing values and operational states

| State | Meaning | Filter behavior |
|---|---|---|
| `KNOWN` | Valid typed normalized value | Included normally |
| `UNKNOWN` | Applicable, not known | Never treated as negative or compatible |
| `NOT_APPLICABLE` | Profile says the concept does not apply | Hidden/excluded |
| `INVALID` | Input cannot meet type/unit rules | Quarantined; source retained |
| `REVIEW_REQUIRED` | Meaning or evidence is ambiguous | Not promoted to governed filter |

## Change safety

- Concept and enum-value identities survive display-name changes.
- Unit conversion rules are versioned; changes trigger comparison/index review.
- Deprecated values map forward with audit history; historical analytics remain
  queryable under the old identity and roll up through explicit mapping.
- No source value is silently overwritten.
- No rule in this document creates owner-final taxonomy, runtime schema or remote data.

`FACET_NORMALIZATION_MODEL: PASS`

`UNKNOWN_IS_FALSE: NO`

`LOSSY_SOURCE_OVERWRITE: FORBIDDEN`
