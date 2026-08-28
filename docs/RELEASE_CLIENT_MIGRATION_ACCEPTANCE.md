# Client Migration Acceptance

State: PROPOSED — OWNER REVIEW REQUIRED

Database success is insufficient if installed clients misread new state.

## Acceptance sequence

1. inventory affected tables, RPCs, fields, invariants, and supported client versions;
2. run migration and backfill in disposable/local then Development;
3. test old-supported and candidate clients before and after migration;
4. verify mixed-version concurrent reads/writes and idempotent retries;
5. validate rollback/forward-fix and alias/compatibility behavior;
6. compare pre/post invariant counts without exposing PII.

Breaking removal waits until old clients are outside the support policy. Taxonomy/product split or merge requires explicit reassignment and stable-ID handling; it must not silently remap historical reviews or purchases.

OWNER_DECISION_REQUIRED: approve supported-client window before any contract phase.
