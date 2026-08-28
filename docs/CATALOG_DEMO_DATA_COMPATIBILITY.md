# Esenler Demo Data Compatibility

Status: **STATIC READ-ONLY ANALYSIS — NO DEMO CHANGE**
Wave: 16, Work Package 34

## Existing dataset

The tracked `esenler_demo_v1` contract contains 4 categories, 20 shared products,
57 synthetic shops and 285 `shop_products` listings. Every product is offered by
14–15 shops with deterministic price variation. Product images/thumbnail and brand
are empty, every shop has five listings, and no auth, review, QR or verified-purchase
rows were seeded. Production apply status is documented by the existing canonical
dataset document; Wave 16 made no remote read or write.

## Fit to target model

| Target concept | Current fit | Future treatment |
| --- | --- | --- |
| Canonical product shared by shops | PASS | Existing 20 product UUIDs already anchor many listings. |
| Shop listing price/availability | PASS with migration caveat | `shop_products` has per-shop price/availability; target makes it authoritative. |
| Variant | MINOR GAP | 20 examples are modeled as single implicit variants; no choice matrix needed for demo behavior. |
| Brand/barcode/provenance | INTENTIONAL GAP | Values are absent; deterministic seed provenance and opaque IDs allow safe candidate mapping. |
| Canonical price/stock separation | MAJOR MIGRATION GAP | Current products carry reference price and stock=100 for compatibility; target does not treat these as universal facts. |
| Taxonomy stable leaf | NEEDS FUTURE MAPPING | Four conceptual mappings exist, but runtime assignable-leaf migration waits for owner-final taxonomy. |
| Custom/variable/policy products | NOT COVERED | Demo is not comprehensive catalog evidence; global stress tests cover these architecture paths. |
| Reviews/verified purchase | NO SEEDED IMPACT | Dataset intentionally has no dependent rows, but live user activity must be inventoried before migration. |

## Per-category notes

- Kırtasiye products include pack/count and paper-size identity signals.
- Electronics products include capacity/power/length/model-like distinctions.
- Food products include fixed net-content pack identities; they are not open-weight
  examples.
- Shoes use generic gender/age/style names but omit explicit size/colour variants.

The dataset can be represented as 20 canonical products, 20 implicit default variants
and 285 listings without changing its customer discovery outcome. That mapping is an
analysis claim only. Future migration must preserve deterministic UUID manifest,
listing price variation and product-to-shop relationships, and must not invent brands,
barcodes, variants, stock accuracy or taxonomy leaf decisions.
