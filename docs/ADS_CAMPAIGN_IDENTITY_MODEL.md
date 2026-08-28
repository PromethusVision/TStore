# Campaign Identity and Versioning Model

**State:** CONCEPTUAL — NO DATABASE IDENTIFIERS GENERATED

## Identity

Each campaign eventually receives an immutable opaque campaign ID. It is not derived
from merchant/shop names, objective, date, slug, product, taxonomy path or budget.
Actual production UUIDs/IDs are not generated in this design.

Related immutable identities:

- campaign revision ID;
- sponsored target and target revision ID;
- budget envelope/ledger identity;
- policy/review decision ID;
- creative/disclosure variant version;
- measurement/attribution ruleset version.

## Editable versus immutable

| Field | Behavior |
|---|---|
| Display name | Mutable; never identity |
| Budget cap/schedule/geo/context | Versioned material settings |
| Target listing | New target revision; identity compatibility/review required |
| Merchant/shop owner | Immutable ownership boundary; transfer requires explicit governance |
| Lifecycle | Effective history; no destructive overwrite |
| Spend/credit/audit events | Immutable facts with corrective events |
| Campaign ID | Never reused for another campaign |

## Pause/resume/retire

Pause/resume keeps campaign ID and records transitions. Ending/retiring prevents new
serving but preserves history. A copied/relaunched campaign receives a new campaign
ID and cannot reset merchant/shop/target frequency, review or abuse history.

## Merge/split dependencies

Product/listing merge may remap only through explicit compatible successor with an
audited target revision. Split pauses until a specific child listing is selected.
Taxonomy rename/move updates targeting metadata without changing campaign identity;
taxonomy split requires target re-resolution.

`CAMPAIGN_ID_IMMUTABLE: YES`

`MATERIAL_EDIT_VERSIONED: YES`

`PRODUCTION_IDS_GENERATED: NO`
