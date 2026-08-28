# Merchant Duplicate Prevention

Status: **OWNER REVIEW DRAFT — NO UI OR SEARCH IMPLEMENTATION**
Wave: 16, Work Package 14

## Prevention sequence

As a merchant types a branded or generic title, the system incrementally suggests
existing catalog identities. Architecture must not depend on any specific brand.

1. Search exact normalized GTIN/ISBN or merchant-scoped SKU history when scanned.
2. Extract and match responsible brand/manufacturer plus model/part number.
3. Retrieve normalized title and synonym candidates within plausible taxonomy.
4. Compare identity-bearing attributes, pack/measure and intrinsic compatibility.
5. Prioritize products the same shop listed before, then verified shared identities
   used by nearby shops; popularity never overrides identity conflict.
6. Group results by canonical product and show variant differences explicitly.
7. Explain each suggestion: identifier match, model match, pack difference, or
   possible duplicate. Never present an opaque score as certainty.

## Decision behavior

| Result | Merchant path |
| --- | --- |
| Exact compatible identifier | Reuse product/variant; merchant creates listing. |
| Product found, variant found | Select variant and attach listing. |
| Product found, variant missing | Propose variant; do not clone product. |
| Possible match | Compare concise identity facts; merchant confirms or requests review. |
| Hard conflict | Keep separate candidate or review; never force link. |
| No safe candidate | Create minimal product candidate with provenance. |

Merchant-entered barcode is an assertion until validated. A local barcode or SKU is
namespaced to the merchant and cannot merge records globally. Repeated dismissal of
strong matches, rapid duplicate creation or conflicting identifiers creates a review
signal, not automatic punishment.

Success metrics should include existing-record reuse rate, duplicate-candidate rate,
false-merge reversals, time-to-list and review burden. Optimizing only reuse rate
would incentivize unsafe merges.
