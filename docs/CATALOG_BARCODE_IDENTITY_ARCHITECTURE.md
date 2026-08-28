# GTIN / EAN / UPC / Barcode Identity Architecture

Status: **OWNER REVIEW DRAFT — NO SCANNER OR SCHEMA IMPLEMENTATION**
Wave: 16, Work Package 4
Research checked: 2026-08-28.

## Standards baseline

GS1 defines GTIN as an identification key for trade items. GTIN-8, GTIN-12
(commonly carried by UPC), GTIN-13 (commonly carried by EAN-13) and GTIN-14 are
representations within the same GTIN family; storage should normalize them to a
canonical GTIN form while preserving the scanned representation and source.
GS1's current General Specifications are version 26.0 (January 2026), and its
GTIN Management Standard governs when a trade item needs a new GTIN.

Authoritative references:

- [GS1 identification keys](https://www.gs1.org/standards/id-keys)
- [GS1 General Specifications 26.0](https://ref.gs1.org/standards/genspecs/)
- [GS1 standards registry and GTIN Management](https://ref.gs1.org/standards/)
- [International ISBN Agency — What is an ISBN?](https://www.isbn-international.org/index.php/content/what-isbn/10)

An ISBN is a 13-digit publication identifier with a check digit; each distinct
edition, language or product format needs its own ISBN. For printed books it can
also be represented in the GS1/retail barcode ecosystem. ISBN is therefore a
global publication identifier, not a merchant SKU.

## Identifier classes

| Class | Examples | Namespace owner | Catalog role |
| --- | --- | --- | --- |
| Global product/trade identifier | GTIN, EAN-13/GTIN-13, UPC/GTIN-12, ISBN-13 | GS1 or ISBN allocation authority/responsible organization | Strong product/variant evidence after validation. |
| Manufacturer identifier | Model number, MPN, part number | Manufacturer/brand owner | Strong within responsible-party namespace; not globally unique alone. |
| Merchant identifier | Shop SKU, merchant-printed barcode, PLU/local code | Individual merchant | Listing lookup only; never global dedup proof. |

The barcode symbol is a carrier. Its payload may be a GTIN, merchant identifier,
variable-measure code or another value; a successful scan does not establish the
identifier type or truth.

## Ingestion and matching rules

1. Preserve raw payload, symbology if known, normalized value, claimed type,
   source, actor, time and validation status.
2. Validate allowed characters, length and check digit where the standard defines
   one. Syntactic validity is necessary, not sufficient.
3. Verify assignment/provenance when an authoritative service or manufacturer
   evidence is available; never infer country of manufacture from a GS1 prefix.
4. Compare brand/manufacturer, model, pack, taxonomy and variant facts. A strong
   conflict prevents automatic merge even when the numeric code matches.
5. Treat GTIN as normally identifying the sellable trade-item/pack configuration;
   several GTINs may validly map to one conceptual product family through separate
   variants/packs or controlled aliases.
6. Reassignment, suspected reuse, duplicate claims or check-digit failure enters
   quarantine/manual review. Never silently move an identifier between active
   identities.

## Edge cases

- **Missing barcode:** match on manufacturer/model/pack and other facts; custom,
  handmade and variable products remain supported with an internal opaque ID.
- **Reused or incorrect barcode:** retain both assertions and provenance; block
  auto-merge, lower confidence, seek package/manufacturer evidence.
- **Multiple GTINs:** allow typed, time-bounded aliases when evidence shows regional
  packaging or a replaced code; use separate variants when the sellable unit differs.
- **Variable measure:** restricted-circulation/in-store encoded values may contain
  price or weight and are merchant/region scoped. Match the base item only through
  an explicitly parsed, trusted rule; never treat the full scan as a global GTIN.
- **Books:** normalize ISBN-13 without hyphens for matching, preserve display form,
  and separate edition/language/format identities.
- **Merchant-generated barcode:** namespace by merchant and bind to the listing;
  identical digits from another merchant are unrelated.
- **Manufacturer part number:** key by manufacturer plus normalized MPN; punctuation
  normalization must not erase significant leading zeros or suffixes.

## Confidence contribution

A verified compatible GTIN can support `EXACT_MATCH`; an unverified valid GTIN is
only one high-weight signal. Conflicting GTINs do not automatically mean different
products because obsolete aliases and data errors exist, but they prevent exact
auto-merge until resolved. No-barcode records may still reach high confidence from
concordant manufacturer, model, pack, attributes and provenance.
