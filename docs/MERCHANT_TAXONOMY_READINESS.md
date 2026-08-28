# EsnaftaVar Merchant/Sector Taxonomy Foundation — Readiness

**Status:** `READY_FOR_OWNER_REVIEW`

**Meaning:** The research/proposal package is internally testable and ready for
Product Owner decisions. It is **not** an owner-final taxonomy and is not ready for
runtime implementation.

## 1. Foundation summary

| Measure | Result |
|---|---:|
| Proposed navigation families | 14 |
| Proposed L2 nodes | 65 |
| Confirmed specialist L3 leaves | 3 |
| Total hierarchy nodes | 82 |
| Assignable merchant-sector leaves | 67 |
| Maximum depth | 3 |
| Default `RETAIL` leaves | 53 |
| Default `SERVICE` leaves | 12 |
| Default `MIXED` leaves | 2 |
| Policy-signalled assignable leaves | 36 |
| `VERIFICATION_MAY_BE_REQUIRED` | 26 |
| `LEGAL_REVIEW_REQUIRED` | 10 |
| `NORMAL` policy classification | 31 |
| Merchant↔product mapping rows | 68 |
| Controlled search aliases | 113 |
| Stress-test cases | 180 |
| Difficult edge cases | 100 |
| Product-decoupling scenarios | 100 |
| Product Owner decisions extracted | 21 |

The 68 mapping rows cover all 67 assignable leaves plus the confirmed beauty
grouping node. The grouping row is not an extra assignable sector.

## 2. Hierarchy readiness

### Strengths

- Common Turkish storefront identities are preferred over legal-code wording.
- Exact duplicate proposed sector names are zero.
- Families and the beauty grouping are proposed non-assignable browse nodes.
- Depth is capped at three; the only L3 leaves are the already-confirmed beauty
  children.
- One primary plus zero-to-three secondary sectors avoids hybrid-node inflation.
- Retail/service/mixed operation is orthogonal to merchant identity.

### Owner-final content already preserved

The following exact subtree is unchanged:

- `Berber, Kuaför & Güzellik Salonu`
  - `Erkek Berberi`
  - `Kadın Kuaförü`
  - `Güzellik Salonu`

Its wider parent placement remains proposed. No additional beauty node was created.
Booking, reservation and service-price architecture remains `TBD`.

## 3. Stress-test results

| Placement result | Cases | Rate |
|---|---:|---:|
| `CLEAR` | 120 | 66.67% |
| `AMBIGUOUS` | 30 | 16.67% |
| `MISSING_SECTOR` | 8 | 4.44% |
| `REGULATORY_REVIEW` | 12 | 6.67% |
| `TOO_BROAD` | 6 | 3.33% |
| `TOO_NARROW` | 4 | 2.22% |
| **Total** | **180** | **100.00%** |

All 67 assignable leaves are represented by at least one case. The results are
diagnostic, not a claim of population-level placement accuracy.

The eight missing/out-of-scope types are pharmacy, veterinary clinic,
cafe/restaurant, automotive repair, photography studio, real-estate office, custom
carpenter/workshop and equipment rental. They expose the owner-level breadth
decision; they are not silently added.

## 4. Edge and granularity findings

The 100 difficult mixed-merchant cases produce 18 reusable boundary rules. The
central rule is that durable business identity drives sector, while each physical
product keeps an independent Product Taxonomy leaf. A shelf, seasonal campaign,
brand, product attribute, service-area mode or store size is not a secondary sector.

Granularity audit across all 82 hierarchy nodes:

| Classification | Nodes |
|---|---:|
| `BALANCED` | 53 |
| `TOO_BROAD` | 3 |
| `TOO_NARROW` | 3 |
| `UNNECESSARY` | 0 |
| `LIKELY_PARENT` | 15 |
| `REGULATED_SPECIAL_CASE` | 8 |
| **Total** | **82** |

Targeted owner review is required for:

- broad `Market, Bakkal & Süpermarket` and two other broad labels identified in the
  audit;
- narrow `İç Giyim Mağazası`, `Parfümeri` and `Ofis Malzemeleri Mağazası`;
- the policy-diverse `Optik, Saat, Takı & Medikal` family;
- `Evcil Hayvan` live-animal/veterinary boundaries;
- `Tamir, Bakım & Yerel Hizmetler` breadth;
- parent-node assignability.

## 5. Product Taxonomy independence

`MERCHANT SECTOR` answers “what kind of business is this?”; `PRODUCT TAXONOMY`
answers “what product is this?”; facets describe product properties. The three
identity systems are not interchangeable.

- Merchant↔product relationship is many-to-many.
- A merchant may list products from any approved Product Taxonomy branch.
- Merchant-sector IDs never derive from Product Taxonomy paths, names or IDs.
- Product-tree rename/move/split/merge does not change merchant identity.
- Merchant-sector change does not bulk-reclassify products.
- Of 100 decoupling scenarios, 54 require no merchant/product mapping change and 46
  require suggestion refresh only; merchant-sector ID changes required: zero.

`PRODUCT_TAXONOMY_INDEPENDENCE: PASS`

## 6. Primary, secondary and operating model readiness

Recommended conceptual contract:

- exactly one effective primary sector;
- zero-to-three effective secondaries;
- a secondary represents an independent recognizable activity, not every inventory
  department;
- cross-family secondary selection is allowed but receives stronger validation;
- `RETAIL`, `SERVICE` and `MIXED` is a separate operating dimension;
- effective-dated history preserves corrections and sector changes;
- sector never grants Auth role, licence, verification, product permission or badge.

This model is ready for owner review. Branch/multi-location inheritance remains an
implementation blocker because the current one-owner/one-shop model is not a final
organization design.

## 7. Policy readiness

Policy signals are intentionally conservative and are not legal advice. Sector
selection alone never establishes compliance.

Before any policy-signalled leaf can launch, Product Owner and responsible legal/
operations stakeholders must define:

1. the launch allowlist;
2. exact declared activity boundary;
3. evidence required and expiry/revocation behavior;
4. accountable review owner;
5. customer-visible badge wording and privacy limits;
6. separate product-level restrictions.

Unresolved controlled activity remains fail-closed. The high 36/67 signal count is
a review prompt, not a recommendation to apply identical friction to every merchant.

## 8. Search and onboarding readiness

- 113 controlled aliases cover all 68 canonical mapping targets (including the
  non-assignable beauty grouping).
- Exact duplicate aliases are zero.
- No company/brand is used as a sector.
- Search-first leaf discovery plus browse families is recommended.
- “Other” records an unresolved request; it never publishes free text.
- The primary choice comes first; secondaries and policy prompts use progressive
  disclosure.
- Alias ambiguity requires disambiguation rather than automatic first-result
  selection.

Field testing with merchants remains necessary before UI/runtime finalization.

## 9. Owner decisions

The owner digest contains 21 explicit decisions:

| Priority | Count | Gate |
|---|---:|---|
| P0 — tree/assignability | 9 | Must precede stable-ID freeze. |
| P1 — app/assignment/verification | 7 | Must precede schema and workflow design. |
| P2 — metadata/governance | 5 | Must precede alias, analytics and badge wiring. |
| **Total** | **21** | — |

Highest-impact decisions are taxonomy breadth, 14-family structure, the 64 proposed
leaves beyond confirmed beauty, parent assignability, family/granularity exceptions,
secondary-sector rules and the regulated-sector launch owner.

## 10. Contrarian verdict

The proposal is not too service-heavy; it is deliberately incomplete outside
product-adjacent services. It may feel too detailed if rendered as a flat selector,
and several family labels resemble product departments. Both risks are manageable
only if search-first onboarding and independent identity namespaces are enforced.

No wholesale redesign is required before owner review. A wider all-local-services
goal would require a separate architecture/research expansion, not incremental
leaf additions.

## 11. Merchant App blockers

Runtime/app design must not begin as though the proposal were final. Blockers are:

1. Product Owner finalization of the merchant tree and assignability.
2. Immutable merchant-sector ID allocation after finalization.
3. Primary/secondary limit and evidence rules.
4. Organization/branch/multi-location ownership decision.
5. Sector-change review and effective-history contract.
6. Regulated launch allowlist, evidence matrix and accountable reviewer.
7. Customer-facing secondary/operating-model/badge presentation.
8. Server-authoritative schema, RLS and lifecycle design in a separately authorized
   runtime wave.

Booking/reservation/service price, service verification/reviews and analytics
infrastructure remain separate `TBD` product areas.

## 12. Deliverables

1. `MERCHANT_TAXONOMY_DESIGN_METHOD.md`
2. `MERCHANT_SECTOR_RESEARCH_INVENTORY.md`
3. `MERCHANT_SECTOR_TAXONOMY_V1_PROPOSAL.md`
4. `MERCHANT_PRODUCT_TAXONOMY_MAPPING.csv`
5. `MERCHANT_PRIMARY_SECONDARY_SECTOR_MODEL.md`
6. `MERCHANT_RETAIL_SERVICE_MIXED_MODEL.md`
7. `MERCHANT_SECTOR_POLICY_AUDIT.md`
8. `MERCHANT_SECTOR_ONBOARDING_FLOW.md`
9. `MERCHANT_SECTOR_SEARCH_SYNONYMS.csv`
10. `MERCHANT_SECTOR_STRESS_TEST.csv`
11. `MERCHANT_SECTOR_EDGE_CASES.md`
12. `MERCHANT_SECTOR_GRANULARITY_AUDIT.md`
13. `MERCHANT_SECTOR_LOCAL_REALISM_AUDIT.md`
14. `MERCHANT_SECTOR_ANALYTICS_MODEL.md`
15. `MERCHANT_SECTOR_IDENTITY_STRATEGY.md`
16. `MERCHANT_PRODUCT_TAXONOMY_DECOUPLING_AUDIT.md`
17. `MERCHANT_TAXONOMY_APP_REQUIREMENTS.md`
18. `MERCHANT_TAXONOMY_OWNER_REVIEW_DIGEST.md`
19. `MERCHANT_TAXONOMY_CONTRARIAN_REVIEW.md`
20. `MERCHANT_TAXONOMY_READINESS.md`

All are analysis/research artifacts. No runtime source, Product Taxonomy source,
database, migration, remote environment, Flutter or Figma asset is part of this
foundation.

## 13. Readiness decision

| Dimension | Result |
|---|---|
| Architecture coherence | PASS |
| Product Taxonomy decoupling | PASS |
| Primary/secondary model | PASS FOR OWNER REVIEW |
| Retail/service/mixed model | PASS FOR OWNER REVIEW |
| Synthetic stress coverage | PASS |
| Confirmed beauty subtree | PRESERVED |
| Policy activation | BLOCKED PENDING OWNER/LEGAL/OPS DECISIONS |
| Runtime readiness | NOT AUTHORIZED / NOT READY |
| Owner-review readiness | READY |

`MERCHANT_TAXONOMY_STATUS: READY_FOR_OWNER_REVIEW`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`
