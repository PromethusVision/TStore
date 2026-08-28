# Catalog Deduplication Failure Registry

Status: **OWNER REVIEW SUPPORT — NOT RUNTIME DEFECT CLAIMS**
Wave: 16, Work Package 38

Evidence reconciled: 504 dedup pairs (48 intentional `UNKNOWN`/manual-review), 480
global identity scenarios (392 `PASS`, 88 classified gaps), 100 merchant profiles
(84 `PASS`, 16 review outcomes) and 150 search scenarios (123 `PASS`, 27 review).
Counts overlap by design; this registry consolidates failure classes rather than
claiming independent production incidents.

| ID | Priority | Failure class | False merge/split risk | Evidence pattern | Required control |
| --- | --- | --- | --- | --- | --- |
| CDF-001 | P0 | Conflicting/reused barcode auto-merge | False merge | Same digits, incompatible brand/model/pack | Identifier quarantine + provenance review |
| CDF-002 | P0 | Product family collapsed with variant | False merge | Same model, different size/capacity/formulation | Domain variant dimensions + hard-conflict gate |
| CDF-003 | P0 | Pack normalization collision | False merge | `2 × 500 ml` treated as `1 L` | Physical pack identity + component measure |
| CDF-004 | P0 | Bundle merged with component | False merge | Product title appears inside set title | Explicit bundle relation/BOM |
| CDF-005 | P0 | Local/variable barcode treated globally | False merge | Merchant PLU or price/weight payload | Merchant namespace + trusted parser rule |
| CDF-006 | P0 | Wrong split rewrites purchase evidence | False split/history loss | Snapshot cannot prove successor | Preserve predecessor; no guessed mapping |
| CDF-007 | P0 | Duplicate-review collision discarded | History loss | Same customer reviewed both duplicates | Owner collision policy + immutable history |
| CDF-008 | P0 | Policy ambiguity bypassed by identity confidence | Unsafe activation | Strong match but regulated status unknown | Independent fail-closed policy gate |
| CDF-009 | P1 | Generic title collision | False merge | Similar normalized title/image, no identifier | Multi-signal threshold/manual review |
| CDF-010 | P1 | Packaging refresh causes false split | False split | New image/title, same verified identity | Alias/effective interval + source evidence |
| CDF-011 | P1 | Model/MPN over-normalization | Both | Significant zero/suffix removed | Manufacturer-scoped raw + normalized forms |
| CDF-012 | P1 | Custom product repeatability unclear | Both | Handmade/generic records across shops | Maker/form/material/measure provenance |
| CDF-013 | P1 | Listing fact becomes canonical identity | False split | Price/stock/title changes create products | Layer ownership validation |
| CDF-014 | P1 | Merchant bypasses strong suggestion | Duplicate record | Repeated candidate despite compatible identity | Explainable existing-first gate/review signal |
| CDF-015 | P1 | Search exposes every listing as product | Perceived duplicates | Same product appears in many shop cards | Product grouping + seller children |
| CDF-016 | P1 | Split/merge alias groups wrong child | False merge | Old link redirected arbitrarily | Typed predecessor graph; ambiguous landing |
| CDF-017 | P2 | Shared/copy media treated as identity proof | False merge | Stock image reused | Media similarity only supporting signal |
| CDF-018 | P2 | Stale aliases create noisy candidate set | Review burden | Historical names/identifiers unbounded | Typed effective aliases and ranking decay |
| CDF-019 | P2 | Cosmetic title differences cause duplicates | False split | Word order/diacritics/punctuation only | Deterministic equivalent normalization |

## Gate summary

- P0: **8** classes; must be owner-resolved or fail-closed before automatic merge.
- P1: **8** classes; V1 needs detection and manual-safe behavior.
- P2: **3** classes; improve precision/operations without blocking identity foundation.
- `UNKNOWN` and review outcomes are expected safety behavior, not an instruction to
  lower thresholds until every row passes.
