# EsnaftaVar Metric Governance

**State:** `PROPOSED`

Each metric has an immutable ID and versioned definition: owner, business question,
formula, accepted event types/versions/authority, entity/time scope, denominator,
filters, privacy class, dimensions, late/correction behavior, freshness/SLA,
validation tests and deprecation successor.

## Change control

- Wording-only clarification with identical computation updates documentation.
- Formula, denominator, filter, identity, taxonomy projection, authority or window
  change creates a new metric-definition version.
- Old and new versions run in parallel for a bounded comparison where practical.
- Dashboards display definition version/effective date and never silently splice
  incompatible history.
- Backfill/restate is explicit, reproducible and labelled; raw facts are unchanged.
- Owner/policy approval is required for new identity linkage, privacy use, ad
  measurement or customer-facing consequences.

Release gates include fixture calculation tests, duplicate/late/correction cases,
source coverage, environment/test filtering, cohort suppression, stakeholder sign-
off and rollback to the prior projection. Metric quality incidents use the failure
registry and do not get “fixed” by manual dashboard edits.

Metric names cannot upgrade evidence: views are not visitors, directions are not
arrivals, verified purchases are not settlement/revenue, and attribution candidates
are not causal conversions.

`SILENT_METRIC_CHANGE: FORBIDDEN`
