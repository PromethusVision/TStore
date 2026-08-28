# EsnaftaVar Merchant Sector Analytics Semantics

**State:** CONCEPTUAL DESIGN — NO DB SCHEMA OR TRACKING IMPLEMENTATION

## 1. Objective

Merchant-sector reporting must remain comparable across renames, moves and merchant
changes without collapsing Product Taxonomy analytics into merchant identity.

Core principle:

- merchant analytics answers **which kinds of businesses participate and perform**;
- product analytics answers **which products/categories are listed, discovered and
  transacted**;
- joining the two can answer cross-sector questions, but neither replaces the other.

## 2. Required semantic dimensions

Future event/reporting contracts should distinguish:

| Dimension | Meaning |
|---|---|
| Merchant location ID | Public-facing branch/location identity. |
| Merchant sector stable ID | Immutable sector identity, never name/path derived. |
| Assignment role | `PRIMARY` or `SECONDARY`. |
| Operating model | `RETAIL`, `SERVICE` or `MIXED`. |
| Effective interval | When the assignment was valid. |
| Taxonomy version | Version used to resolve labels/parents. |
| Assignment source | Merchant declaration, reviewed correction, admin/policy decision or future suggestion acceptance. |
| Verification state | Separate policy state; must not be inferred from sector. |
| Product category stable ID | Independent Product Taxonomy identity for product/listing events. |

This is a semantics contract, not a proposed table definition.

## 3. Primary-sector reporting

- Count each merchant location once under the primary sector valid at the reporting
  event/time.
- For “current merchant base,” use the current active assignment.
- For historical cohort or transaction reports, use the event-time assignment unless
  a report explicitly requests a restated current hierarchy.
- Roll up through the parent relation of the selected taxonomy version.
- Never group by mutable display name alone.

Recommended baseline KPIs:

- active merchant locations by primary sector;
- onboarded/activated merchants by primary sector and cohort;
- listings/verified transactions per primary-sector merchant;
- retention/activity by primary sector;
- policy-review queue and activation latency by policy class.

These are future concepts; current project state has no analytics/event system.

## 4. Secondary-sector reporting

- Secondary sectors are multi-valued; summing them produces counts greater than the
  merchant population.
- Reports must label metrics as either `merchant locations with sector` or
  `sector assignments`, never ambiguously “merchant count.”
- Primary and secondary must be separately filterable.
- A secondary-sector attribution must not claim that all merchant revenue belongs to
  that secondary without direct evidence.
- For cross-sector combinations, report unordered pairs or explicitly directed
  primary→secondary pairs.

## 5. Sector history

Every material assignment change should be effective-dated. Historical records must
preserve:

- prior sector stable ID and role;
- successor sector stable ID and role;
- change time and reason class;
- actor/source class without exposing private evidence;
- taxonomy version and policy status.

Correction and real business change are different reasons. A data correction may
support restated-quality reporting, while a real sector move should remain visible
as business history.

## 6. Rename, move, merge, split and retire

| Taxonomy change | Analytics rule |
|---|---|
| Rename | Stable ID remains; continuity automatic. Historical labels can render by version. |
| Move | Stable ID normally remains; leaf continuity survives, parent rollups vary by taxonomy version. |
| Merge | Preserve predecessor IDs and explicit successor; offer historical and harmonized rollups. |
| Split | Never assign all predecessor history to one arbitrary child. Historical data stays on predecessor unless deterministic evidence supports disaggregation. |
| Retire | Historical ID remains reportable; no new assignments. |

## 7. Cross-sector merchants

For a merchant with primary `Kırtasiye` and secondary `Kitapçı`:

- merchant-base primary report counts it once under Kırtasiye;
- “has sector” report includes it under both, with multi-count warning;
- cross-sector report records Kırtasiye→Kitapçı;
- a book transaction is still attributed to its Product Taxonomy book leaf;
- sector-driven revenue attribution is not inferred without item/service linkage.

## 8. Product-category analytics separation

Never copy merchant-sector IDs into product-category fields or derive one from the
other. Safe analytical joins use explicit facts:

```text
merchant location → effective merchant-sector assignment
merchant location → listing/transaction → product → Product Taxonomy leaf
```

This permits questions such as “Which Product L1s are sold by telefoncu merchants?”
without claiming that Telefoncu owns those product categories.

## 9. Branch and chain reporting

- Default unit is merchant location/branch.
- Legal-entity or chain rollups are separate dimensions.
- A multi-format chain can have different branch primary sectors.
- Company-level deduplication must not erase location-level discovery truth.
- Separately operated departments remain separate merchants if represented that way
  operationally.

## 10. Data-quality indicators

Future reporting should surface:

- missing or unresolved primary assignment;
- excessive/unreviewed secondary assignments;
- retired-node assignment attempts;
- regulated sector without applicable review state;
- conflicting overlapping effective periods;
- alias-only label used as identity;
- taxonomy-version mismatch;
- catalog-based sector suggestion versus merchant-confirmed assignment.

## 11. Privacy and policy

- Verification documents, licence details and free-text evidence do not belong in
  broad analytics events.
- Reports should use approved status/reason classes and minimum necessary data.
- Small-cell or sensitive-sector reporting may need access/aggregation controls in a
  future analytics design.
- No analytics or event instrumentation exists in the current project state; this
  document does not add it.

## 12. Owner decisions

1. Choose event-time versus current-hierarchy default for executive reporting.
2. Decide whether correction events can restate historical dashboards.
3. Define secondary-sector attribution semantics for revenue/activity.
4. Assign governance for taxonomy-version and successor-graph releases.
5. Decide privacy thresholds for policy-sensitive sector reporting.

`MERCHANT_SECTOR_ANALYTICS_MODEL: DESIGN_READY_FOR_OWNER_REVIEW`

`PRODUCT_ANALYTICS_DECOUPLED: YES`
