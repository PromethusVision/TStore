# Backend Correction Event Model

**State:** PROPOSED — NO EVENT/SCHEMA IMPLEMENTATION

A correction records that a prior authoritative fact, mapping or projection was
wrong, disputed, voided or superseded. It never pretends the original did not
exist.

## Envelope

- correction ID/type and trusted time;
- exact subject and predecessor fact/revision;
- reason/evidence/policy version and restricted case;
- authorized actor/approver;
- corrected/superseding identity or state;
- affected projections and reconciliation status;
- customer/merchant communication and appeal class where applicable.

## Application

Product merges/splits append lineage; purchase correction appends integrity state;
review correction preserves revisions; reward uses compensating ledger entries;
reputation reclassifies evidence and rebuilds projection; analytics restates a
versioned window. No direct balance/aggregate overwrite is the source of truth.

Consumers deduplicate correction ID, process causal predecessor, and quarantine
missing/unsupported versions. Cascading corrections are idempotent and observable.
Exact customer-visible correction messages and irreversible classes remain
`OWNER_DECISION_REQUIRED`.

