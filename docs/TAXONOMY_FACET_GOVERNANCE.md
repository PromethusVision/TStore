# EsnaftaVar Facet Governance

**State:** `PROVISIONAL GOVERNANCE PROPOSAL — OWNER REVIEW REQUIRED`  
**Applies to:** concept facets, values, aliases, profiles, compatibility inputs,
policy metadata and search-index impact  
**Runtime authority created:** None

## Roles

| Role | Responsibility | Cannot do alone |
|---|---|---|
| Product Owner | Approves semantic product/facet boundaries and merchant/customer behavior | Legal/policy approval; direct Production changes |
| Taxonomy steward | Detects reuse/collision, maintains proposal registry and profile consistency | Finalize owner decisions or policy eligibility |
| Domain specialist | Validates technical meaning, units, values and applicability | Create global duplicate concepts |
| Search owner | Owns aliases/synonyms, collision tests and index impact | Change taxonomy ownership via synonym |
| Policy/legal owner | Approves evidence, restriction and eligibility semantics | Turn policy class into category depth |
| Data/runtime owner | Implements approved versioned contract and migrations | Invent semantic decisions during implementation |
| Analytics owner | Validates metric continuity and mapping | Treat renamed display labels as new concepts |

Role names describe future responsibilities; they do not assign people or create an
organizational authorization system in this task.

## New facet proposal gate

A facet may be proposed only when all are documented:

1. a real physical-product question not already answered by taxonomy, listing,
   compatibility or policy;
2. searched/displayed/validated operational use;
3. existing-concept reuse analysis and alias collision scan;
4. data type, value mode, unit family, cardinality and scope;
5. applicable and non-applicable leaf/profile examples;
6. category-confusion risk and product/variant/listing layer;
7. normalization, source/provenance and privacy/policy considerations;
8. search/index/analytics/backward-compatibility impact;
9. owner(s) and decision state.

Incomplete proposals remain draft and never appear as free-text production fields.

## Reuse before creation

- Same meaning + data type + unit family + cardinality → reuse concept.
- Different UI wording → add a label alias/locale label.
- Narrower leaf applicability → profile constraint, not new concept.
- Different evidence/eligibility → policy metadata, not duplicate product facet.
- Different physical meaning (`screen size` vs product dimensions) → separate concepts.
- Ambiguous term (`size`, `model`, `batarya`) → disambiguated technical key and
  scope; never a broad catch-all.

## Naming standard

- Concept display names: concise singular Turkish noun phrase.
- Proposed technical keys: lowercase ASCII `snake_case`, semantic, no unit suffix.
- IDs: stable opaque/runtime identity in the future; current `FACET-*` are concept
  IDs only and must not be copied as production UUIDs.
- No brand, model, merchant, campaign, value or locale in concept identity.
- Boolean names express objective property, not negative/double-negative wording.
- Policy and compatibility concepts are visibly separated from ordinary facets.

## Data-type immutability

Once runtime data exists, changing type/cardinality/unit family is a breaking change,
not a label edit. Required process:

1. impact inventory and value-quality report;
2. new concept/version or explicit safe conversion design;
3. dual-read/backfill/validation plan if needed;
4. search/filter/analytics regression test;
5. rollback/forward-fix expectation;
6. owner approval before cutover;
7. old identity retained for history/aliasing.

No destructive migration is authorized by this document.

## Value lifecycle

| Action | Required controls |
|---|---|
| Add value | semantic uniqueness, aliases, affected profiles, search collision and policy evidence |
| Rename display | stable value identity, locale update, analytics/index verification |
| Merge values | explicit canonical successor, source preservation, ambiguity/compatibility audit |
| Split value | deterministic mapping where possible; unresolved records to review |
| Deprecate | replacement/reason/effective date, legacy read and analytics mapping |
| Delete | normally forbidden once referenced; privacy/legal deletion handled separately |

## Alias handling

- Label alias: alternate UI/import wording for one concept/value.
- Search synonym: discovery-only term; cannot populate product facts.
- Legacy alias: retained mapping with lower precedence and deprecation telemetry.
- Typo: search correction layer by default, not governed synonym.
- One alias cannot map to multiple concepts without explicit context/collision rule.

## Unit changes

- Canonical numeric value and unit-family identity remain stable.
- Display-unit preference can change without rewriting source facts.
- A new unit enters only with exact/reviewed conversion and precision rules.
- Approximate shoe/ring/apparel conversions are versioned lookup aids, not unit math.
- Unit changes trigger sorting/range-filter and compatibility regression tests.

## Backward compatibility and analytics

- Stable concept/value identity survives display-label changes.
- Every merge/split/deprecation publishes a versioned successor mapping.
- Historical events retain original identity and can roll up through explicit maps.
- Dashboards declare taxonomy/facet/profile version used.
- An alias or normalization change is monitored for traffic/result distribution shifts.
- Re-indexing is explicit; production index state cannot silently diverge from the
  approved dictionary.

## Merchant-facing label changes

Copy changes require language/usability review but do not change concept identity.
Merchant forms show migration guidance only when input meaning/requirements change.
An existing merchant value is not erased because a label changed. New required
fields need readiness, default/backfill policy and draft/listing impact decision.

## Search index impact classification

| Change | Impact | Minimum gate |
|---|---|---|
| Display label only | LOW | exact canonical-name test and analytics label check |
| Add synonym/alias | MEDIUM | collision audit and precision/recall evaluation |
| Change synonym target | HIGH | owner/search approval, before/after query set |
| Add/change filterable facet | HIGH | data coverage, normalization and UI/index contract |
| Change unit/type/cardinality | CRITICAL | versioned migration plan and rollback/forward-fix |
| Policy/compatibility semantic change | CRITICAL | policy/domain owner plus safety regression |

## Versioning and review cadence

- Registry, dictionary, profile, value vocabulary, synonym and compatibility rule
  versions are separate but release-compatible manifests in a future implementation.
- Emergency policy disablement may fail closed without taxonomy deletion.
- Quarterly or evidence-driven quality review should inspect duplicate concepts,
  unknown values, free-text leakage, collision metrics and unused facets.
- Owner-final states are only recorded after explicit Product Owner decision.

## Required change record

Every future governed change should state: proposal ID, author/owners, problem,
before/after semantics, impacted domains/leaves, status, evidence, migration/index/
analytics impact, validation, rollout/rollback expectation and effective version.

## Current review queue

- 88 provisional facet concepts and their scope/profile applicability;
- 10 product/variant/listing owner questions;
- 18 earlier global L2 root decisions (unchanged by this architecture);
- policy/legal evidence classes and fail-closed domain posture;
- runtime IDs/schema/index and actual organizational role assignment.

`FACET_GOVERNANCE: READY_FOR_OWNER_REVIEW`

`UNAPPROVED_RUNTIME_CHANGE: FORBIDDEN`

`OWNER_FINALIZATION_PERFORMED: NO`
